using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/crm")]
    [ApiController]
    public class CrmAdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CrmAdminController(AppDbContext context)
        {
            _context = context;
        }

        // 1. Lấy danh sách khách hàng kèm hồ sơ nhân khẩu học
        [HttpGet("customers")]
        public async Task<IActionResult> GetCustomers()
        {
            var customers = await _context.Accounts
                .Include(a => a.Role)
                .Where(a => a.Role != null && a.Role.RoleName == "Customer")
                .Select(a => new
                {
                    a.AccountId,
                    a.Username,
                    a.FullName,
                    a.Email,
                    a.Phone,
                    a.IsActive,
                    a.CreatedAt,
                    Profile = _context.CustomerProfiles.FirstOrDefault(p => p.AccountId == a.AccountId)
                })
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();

            return Ok(customers);
        }

        // 2. Thêm khách hàng mới (Mục 4.1.1)
        [HttpPost("customers")]
        public async Task<IActionResult> CreateCustomer([FromBody] CustomerRegisterDto dto)
        {
            if (await _context.Accounts.AnyAsync(a => a.Username == dto.Username))
                return BadRequest(new { message = "Tên đăng nhập đã tồn tại!" });

            var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
            if (customerRole == null)
                return BadRequest(new { message = "Chưa cấu hình Role Customer trong CSDL." });

            var account = new Account
            {
                Username = dto.Username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                RoleId = customerRole.RoleId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            _context.Accounts.Add(account);
            await _context.SaveChangesAsync();

            var profile = new CustomerProfile
            {
                AccountId = account.AccountId,
                Age = dto.Age,
                Gender = dto.Gender,
                Address = dto.Address,
                Interest = dto.Interest
            };

            _context.CustomerProfiles.Add(profile);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Thêm khách hàng mới thành công!", accountId = account.AccountId });
        }

        // 3. Xóa khách hàng (Mục 4.1.2)
        [HttpDelete("customers/{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            var account = await _context.Accounts.FindAsync(id);
            if (account == null) return NotFound(new { message = "Không tìm thấy khách hàng." });

            _context.Accounts.Remove(account);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa khách hàng thành công." });
        }

        // 4. Khóa / Mở khóa tài khoản khách hàng (Mục 4.1.3)
        [HttpPut("customers/{id}/toggle-status")]
        public async Task<IActionResult> ToggleCustomerStatus(int id)
        {
            var account = await _context.Accounts.FindAsync(id);
            if (account == null) return NotFound(new { message = "Không tìm thấy khách hàng." });

            account.IsActive = !account.IsActive;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = account.IsActive ? "Đã mở khóa tài khoản khách hàng." : "Đã khóa tài khoản khách hàng.",
                isActive = account.IsActive
            });
        }

        // 5. Tiếp nhận và trả lời phản hồi khách hàng (Mục 4.1.4)
        [HttpGet("feedbacks")]
        public async Task<IActionResult> GetFeedbacks()
        {
            var list = await _context.Feedbacks
                .Include(f => f.Account)
                .Include(f => f.Product)
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new
                {
                    f.FeedbackId,
                    f.AccountId,
                    CustomerName = f.Account != null ? f.Account.FullName : "Khách hàng",
                    f.ProductId,
                    ProductName = f.Product != null ? f.Product.ProductName : "Sản phẩm",
                    f.Rating,
                    f.Comment,
                    f.AdminReply,
                    f.Status,
                    f.CreatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        [HttpPut("feedbacks/{id}/reply")]
        public async Task<IActionResult> ReplyFeedback(int id, [FromBody] FeedbackReplyDto dto)
        {
            var fb = await _context.Feedbacks.FindAsync(id);
            if (fb == null) return NotFound(new { message = "Không tìm thấy phản hồi." });

            fb.AdminReply = dto.AdminReply;
            fb.Status = "Đã tiếp nhận & Xử lý";
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã gửi phản hồi cho khách hàng." });
        }

        // 6. Báo cáo tỷ lệ độ tuổi và sở thích khách hàng (Mục 4.1.5)
        [HttpGet("reports/demographics")]
        public async Task<IActionResult> GetDemographicsReport()
        {
            var profiles = await _context.CustomerProfiles.ToListAsync();
            int total = profiles.Count;

            var ageStats = new
            {
                Under20 = profiles.Count(p => p.Age < 20),
                From20To30 = profiles.Count(p => p.Age >= 20 && p.Age <= 30),
                Over30 = profiles.Count(p => p.Age > 30)
            };

            var interestStats = profiles
                .GroupBy(p => string.IsNullOrEmpty(p.Interest) ? "Khác" : p.Interest)
                .Select(g => new
                {
                    Interest = g.Key,
                    Count = g.Count(),
                    Percentage = total > 0 ? Math.Round((double)g.Count() * 100 / total, 1) : 0
                })
                .ToList();

            return Ok(new { totalCustomers = total, ageStats, interestStats });
        }

        // 7. Tạo khảo sát sản phẩm mới & Thống kê kết quả (Mục 4.1.6 & 4.1.7)
        [HttpGet("surveys")]
        public async Task<IActionResult> GetSurveys()
        {
            var surveys = await _context.Surveys
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => new
                {
                    s.SurveyId,
                    s.Title,
                    s.Description,
                    s.TargetProduct,
                    s.ExpectedPrice,
                    s.CreatedAt,
                    s.IsActive,
                    TotalResponses = _context.SurveyResponses.Count(r => r.SurveyId == s.SurveyId)
                })
                .ToListAsync();

            return Ok(surveys);
        }

        [HttpPost("surveys")]
        public async Task<IActionResult> CreateSurvey([FromBody] SurveyCreateDto dto)
        {
            var survey = new Survey
            {
                Title = dto.Title,
                Description = dto.Description,
                TargetProduct = dto.TargetProduct,
                ExpectedPrice = dto.ExpectedPrice,
                CreatedAt = DateTime.Now,
                IsActive = true
            };

            _context.Surveys.Add(survey);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã phát hành bảng khảo sát mới!", surveyId = survey.SurveyId });
        }

        [HttpGet("surveys/{id}/statistics")]
        public async Task<IActionResult> GetSurveyStatistics(int id)
        {
            var survey = await _context.Surveys.FindAsync(id);
            if (survey == null) return NotFound(new { message = "Không tìm thấy khảo sát." });

            var responses = await _context.SurveyResponses
                .Include(r => r.Account)
                .Where(r => r.SurveyId == id)
                .OrderByDescending(r => r.SubmittedAt)
                .ToListAsync();

            int total = responses.Count;
            double avgScore = total > 0 ? Math.Round(responses.Average(r => r.Score), 2) : 0;

            var intentStats = new
            {
                WantToBuy = responses.Count(r => r.BuyingIntent == "Rất muốn mua"),
                Considering = responses.Count(r => r.BuyingIntent == "Đang cân nhắc"),
                NotBuying = responses.Count(r => r.BuyingIntent == "Không mua")
            };

            var detailResponses = responses.Select(r => new
            {
                r.ResponseId,
                CustomerName = r.Account != null ? r.Account.FullName : "Khách hàng",
                r.Score,
                r.BuyingIntent,
                r.CustomerOpinion,
                r.SubmittedAt
            });

            return Ok(new
            {
                survey.SurveyId,
                survey.Title,
                survey.TargetProduct,
                survey.ExpectedPrice,
                totalResponses = total,
                averageScore = avgScore,
                intentStats,
                detailResponses
            });
        }
    }
}