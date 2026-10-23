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
            var list = await _context.Accounts
                .Include(a => a.Role)
                .OrderByDescending(a => a.AccountId)
                .Select(a => new
                {
                    a.AccountId,
                    a.Username,
                    a.FullName,
                    a.Email,
                    a.Phone,
                    a.RoleId,
                    RoleName = a.Role != null ? a.Role.RoleName : "",
                    a.IsActive,
                    a.CreatedAt
                })
                .ToListAsync();
            return Ok(list);
        }

        [HttpGet("roles")]
        public async Task<IActionResult> GetRoles() => Ok(await _context.Roles.ToListAsync());

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] AccountCreateDto dto)
        {
            if (await _context.Accounts.AnyAsync(a => a.Username == dto.Username))
                return BadRequest(new { message = "Username đã tồn tại!" });

            var acc = new Account
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                RoleId = dto.RoleId,
                IsActive = true
            };
            _context.Accounts.Add(acc);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Tạo tài khoản thành công!" });
        }

        [HttpPut("{id}/role")]
        public async Task<IActionResult> UpdateRole(int id, [FromBody] UpdateRoleDto dto)
        {
            var acc = await _context.Accounts.FindAsync(id);
            if (acc == null) return NotFound();
            acc.RoleId = dto.RoleId;
            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật phân quyền thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var acc = await _context.Accounts.FindAsync(id);
            if (acc == null) return NotFound();
            _context.Accounts.Remove(acc);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa tài khoản!" });
        }
    }
}