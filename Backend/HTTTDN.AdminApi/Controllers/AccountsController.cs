using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/accounts")]
    [ApiController]
    public class AccountsController : ControllerBase
    {
        private readonly AppDbContext _context;
        public AccountsController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var allowedRoles = new[] { "Admin", "Manager", "Customer" };

            var list = await _context.Accounts
                .Include(a => a.Role)
                .Where(a => a.Role == null || allowedRoles.Contains(a.Role.RoleName))
                .OrderByDescending(a => a.AccountId)
                .Select(a => new
                {
                    a.AccountId,
                    a.Username,
                    a.FullName,
                    a.Email,
                    a.Phone,
                    a.RoleId,
                    RoleName = a.Role != null ? a.Role.RoleName : "Customer",
                    a.IsActive,
                    a.CreatedAt
                })
                .ToListAsync();
            return Ok(list);
        }

        // Chỉ trả về đúng 3 quyền: Admin, Manager, Customer
        [HttpGet("roles")]
        public async Task<IActionResult> GetRoles()
        {
            var allowedRoles = new[] { "Admin", "Manager", "Customer" };
            var roles = await _context.Roles
                .Where(r => allowedRoles.Contains(r.RoleName))
                .ToListAsync();
            return Ok(roles);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] AccountCreateDto dto)
        {
            if (await _context.Accounts.AnyAsync(a => a.Username.ToLower() == dto.Username.Trim().ToLower()))
                return BadRequest(new { message = "Username đã tồn tại!" });

            var acc = new Account
            {
                Username = dto.Username.Trim(),
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName.Trim(),
                Email = dto.Email,
                Phone = dto.Phone,
                RoleId = dto.RoleId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };
            _context.Accounts.Add(acc);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Tạo tài khoản thành công!" });
        }

        // Cho phép Admin đổi quyền của bất kỳ tài khoản nào (kể cả Admin khác)
        [HttpPut("{id}/role")]
        public async Task<IActionResult> UpdateRole(int id, [FromBody] UpdateRoleDto dto)
        {
            var acc = await _context.Accounts.FindAsync(id);
            if (acc == null) return NotFound(new { message = "Không tìm thấy tài khoản!" });

            acc.RoleId = dto.RoleId;
            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật phân quyền thành công!" });
        }

        // Cho phép Admin xóa bất kỳ Admin khác hoặc tài khoản khác
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var acc = await _context.Accounts.FindAsync(id);
            if (acc == null)
                return NotFound(new { message = "Không tìm thấy tài khoản!" });

            // Xóa dữ liệu liên quan (nếu có) để tránh lỗi khóa ngoại SQL Server
            var profiles = await _context.CustomerProfiles.Where(p => p.AccountId == id).ToListAsync();
            if (profiles.Any()) _context.CustomerProfiles.RemoveRange(profiles);

            var feedbacks = await _context.Feedbacks.Where(f => f.AccountId == id).ToListAsync();
            if (feedbacks.Any()) _context.Feedbacks.RemoveRange(feedbacks);

            var responses = await _context.SurveyResponses.Where(r => r.AccountId == id).ToListAsync();
            if (responses.Any()) _context.SurveyResponses.RemoveRange(responses);

            _context.Accounts.Remove(acc);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa tài khoản thành công!" });
        }
    }
}