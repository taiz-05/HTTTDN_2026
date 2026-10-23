using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/customer")]
    [ApiController]
    public class CustomerPortalController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CustomerPortalController(AppDbContext context)
        {
            _context = context;
        }

        // 1. Đăng ký tài khoản khách hàng (Mục 4.3.1)
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] CustomerRegisterDto dto)
        {
            if (await _context.Accounts.AnyAsync(a => a.Username == dto.Username))
                return BadRequest(new { message = "Tên đăng nhập đã được sử dụng!" });

            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
            if (role == null) return BadRequest(new { message = "Chưa có Role Customer." });

            var acc = new Account
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                RoleId = role.RoleId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            _context.Accounts.Add(acc);
            await _context.SaveChangesAsync();

            var profile = new CustomerProfile
            {
                AccountId = acc.AccountId,
                Age = dto.Age,
                Gender = dto.Gender,
                Address = dto.Address,
                Interest = dto.Interest
            };

            _context.CustomerProfiles.Add(profile);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đăng ký tài khoản thành công!", accountId = acc.AccountId });
        }

        // 2. Đăng nhập dành cho khách hàng (Mục 4.3.2)
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
        {
            var acc = await _context.Accounts
                .Include(a => a.Role)
                .FirstOrDefaultAsync(a => a.Username == dto.Username);

            if (acc == null || acc.Role?.RoleName != "Customer")
                return Unauthorized(new { message = "Tài khoản khách hàng không tồn tại!" });

            if (!acc.IsActive)
                return Unauthorized(new { message = "Tài khoản của bạn đã bị khóa bởi người quản lý!" });

            bool validPass = acc.PasswordHash == dto.Password ||
                             (acc.PasswordHash.StartsWith("$2") && BCrypt.Net.BCrypt.Verify(dto.Password, acc.PasswordHash));

            if (!validPass)
                return Unauthorized(new { message = "Mật khẩu không chính xác!" });

            return Ok(new
            {
                accountId = acc.AccountId,
                username = acc.Username,
                fullName = acc.FullName,
                role = acc.Role.RoleName
            });
        }

        // 3. Xem và chỉnh sửa thông tin cá nhân (Mục 4.3.3)
        [HttpGet("profile/{accountId}")]
        public async Task<IActionResult> GetProfile(int accountId)
        {
            var acc = await _context.Accounts.FindAsync(accountId);
            if (acc == null) return NotFound();

            var profile = await _context.CustomerProfiles.FirstOrDefaultAsync(p => p.AccountId == accountId);
            return Ok(new
            {
                acc.AccountId,
                acc.Username,
                acc.FullName,
                acc.Email,
                acc.Phone,
                Age = profile?.Age ?? 20,
                Gender = profile?.Gender ?? "Nam",
                Address = profile?.Address ?? "",
                Interest = profile?.Interest ?? "Văn phòng"
            });
        }

        [HttpPut("profile/{accountId}")]
        public async Task<IActionResult> UpdateProfile(int accountId, [FromBody] CustomerUpdateProfileDto dto)
        {
            var acc = await _context.Accounts.FindAsync(accountId);
            if (acc == null) return NotFound();

            acc.FullName = dto.FullName;
            acc.Email = dto.Email;
            acc.Phone = dto.Phone;

            var profile = await _context.CustomerProfiles.FirstOrDefaultAsync(p => p.AccountId == accountId);
            if (profile == null)
            {
                profile = new CustomerProfile { AccountId = accountId };
                _context.CustomerProfiles.Add(profile);
            }

            profile.Age = dto.Age;
            profile.Gender = dto.Gender;
            profile.Address = dto.Address;
            profile.Interest = dto.Interest;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật thông tin hồ sơ thành công!" });
        }

        // 4. Gửi phản hồi về sản phẩm & xem lịch sử phản hồi (Mục 4.3.4)
        [HttpGet("feedbacks/{accountId}")]
        public async Task<IActionResult> GetMyFeedbacks(int accountId)
        {
            var list = await _context.Feedbacks
                .Include(f => f.Product)
                .Where(f => f.AccountId == accountId)
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new
                {
                    f.FeedbackId,
                    f.ProductId,
                    ProductName = f.Product != null ? f.Product.ProductName : "",
                    f.Rating,
                    f.Comment,
                    f.AdminReply,
                    f.Status,
                    f.CreatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        [HttpPost("feedbacks/{accountId}")]
        public async Task<IActionResult> CreateFeedback(int accountId, [FromBody] FeedbackCreateDto dto)
        {
            var fb = new Feedback
            {
                AccountId = accountId,
                ProductId = dto.ProductId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                Status = "Chờ xử lý",
                CreatedAt = DateTime.Now
            };

            _context.Feedbacks.Add(fb);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Cảm ơn bạn đã gửi đánh giá sản phẩm!" });
        }

        // 5. Nhận khảo sát sản phẩm mới và thực hiện (Mục 4.3.5)
        [HttpGet("surveys/{accountId}")]
        public async Task<IActionResult> GetAvailableSurveys(int accountId)
        {
            var surveys = await _context.Surveys
                .Where(s => s.IsActive)
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => new
                {
                    s.SurveyId,
                    s.Title,
                    s.Description,
                    s.TargetProduct,
                    s.ExpectedPrice,
                    s.CreatedAt,
                    IsCompleted = _context.SurveyResponses.Any(r => r.SurveyId == s.SurveyId && r.AccountId == accountId)
                })
                .ToListAsync();

            return Ok(surveys);
        }

        [HttpPost("surveys/{surveyId}/submit/{accountId}")]
        public async Task<IActionResult> SubmitSurvey(int surveyId, int accountId, [FromBody] SurveyAnswerDto dto)
        {
            bool exists = await _context.SurveyResponses.AnyAsync(r => r.SurveyId == surveyId && r.AccountId == accountId);
            if (exists)
                return BadRequest(new { message = "Bạn đã thực hiện bài khảo sát này rồi!" });

            var resp = new SurveyResponse
            {
                SurveyId = surveyId,
                AccountId = accountId,
                Score = dto.Score,
                BuyingIntent = dto.BuyingIntent,
                CustomerOpinion = dto.CustomerOpinion,
                SubmittedAt = DateTime.Now
            };

            _context.SurveyResponses.Add(resp);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Gửi kết quả khảo sát thành công! Cảm ơn ý kiến đóng góp của bạn." });
        }
    }
}