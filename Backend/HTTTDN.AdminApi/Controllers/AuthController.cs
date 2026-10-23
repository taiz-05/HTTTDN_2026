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
        public AuthController(AppDbContext context) => _context = context;

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
        {
            var acc = await _context.Accounts
                .Include(a => a.Role)
                .FirstOrDefaultAsync(a => a.Username == dto.Username.Trim());

            if (acc == null)
                return Unauthorized(new { message = "Tài khoản không tồn tại!" });

            if (!acc.IsActive)
                return Unauthorized(new { message = "Tài khoản đã bị khóa!" });

            string inputPass = dto.Password.Trim();
            string dbPass = (acc.PasswordHash ?? "").Trim();

            bool valid = false;

            // 1. Khớp trực tiếp hoặc mật khẩu demo '123456'
            if (dbPass == inputPass || inputPass == "123456")
            {
                valid = true;
            }
            // 2. Kiểm tra BCrypt nếu là chuỗi băm hợp lệ (bọc try-catch chống lỗi hash giả)
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
                return Unauthorized(new { message = "Sai mật khẩu!" });

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