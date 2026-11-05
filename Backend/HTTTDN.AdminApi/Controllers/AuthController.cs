using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
        {
            string username = (dto.Username ?? "").Trim();
            string inputPass = (dto.Password ?? "").Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(inputPass))
            {
                return BadRequest(new { message = "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!" });
            }

            // Tìm tài khoản không phân biệt chữ hoa / chữ thường
            var acc = await _context.Accounts
                .Include(a => a.Role)
                .FirstOrDefaultAsync(a => a.Username.ToLower() == username.ToLower());

            if (acc == null)
            {
                return Unauthorized(new { message = "Tài khoản không tồn tại!" });
            }

            if (!acc.IsActive)
            {
                return Unauthorized(new { message = "Tài khoản này đã bị khóa!" });
            }

            string dbPass = (acc.PasswordHash ?? "").Trim();
            bool valid = false;

            // 1. Kiểm tra khớp trực tiếp hoặc mật khẩu demo '123456'
            if (dbPass == inputPass || inputPass == "123456")
            {
                valid = true;
            }
            // 2. Kiểm tra mã băm BCrypt (bọc try-catch để tránh lỗi nếu chuỗi hash cũ không hợp lệ)
            else if (dbPass.StartsWith("$2"))
            {
                try
                {
                    valid = BCrypt.Net.BCrypt.Verify(inputPass, dbPass);
                }
                catch
                {
                    valid = false;
                }
            }

            if (!valid)
            {
                return Unauthorized(new { message = "Sai mật khẩu!" });
            }

            return Ok(new
            {
                accountId = acc.AccountId,
                username = acc.Username,
                fullName = acc.FullName,
                roleId = acc.RoleId,
                roleName = acc.Role?.RoleName ?? "Customer"
            });
        }
    }
}