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

        [HttpPost("customers")]
        public async Task<IActionResult> CreateCustomer([FromBody] CustomerRegisterDto dto)
        {
            string username = (dto.Username ?? "").Trim();
            string fullName = (dto.FullName ?? "").Trim();
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(fullName))
                return BadRequest(new { message = "Vui lòng nhập đầy đủ Tên đăng nhập và Họ tên khách hàng!" });

            if (await _context.Accounts.AnyAsync(a => a.Username.ToLower() == username.ToLower()))
                return BadRequest(new { message = "Tên đăng nhập đã tồn tại!" });

            var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
            if (customerRole == null)
                return BadRequest(new { message = "Chưa cấu hình Role Customer trong CSDL." });

            string rawPass = string.IsNullOrWhiteSpace(dto.Password) ? "123456" : dto.Password.Trim();
            string email = string.IsNullOrWhiteSpace(dto.Email)
                ? $"{username.ToLower()}@customer.sgutech.vn"
                : dto.Email.Trim();

            var account = new Account
            {
                Username = username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(rawPass),
                FullName = fullName,
                Email = email,
                Phone = (dto.Phone ?? "").Trim(),
                RoleId = customerRole.RoleId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            _context.Accounts.Add(account);
            await _context.SaveChangesAsync();

            var profile = new CustomerProfile
            {
                AccountId = account.AccountId,
                Age = dto.Age > 0 ? dto.Age : 20,
                Gender = string.IsNullOrWhiteSpace(dto.Gender) ? "Nam" : dto.Gender,
                Address = string.IsNullOrWhiteSpace(dto.Address) ? "TP. Hồ Chí Minh" : dto.Address.Trim(),
                Interest = string.IsNullOrWhiteSpace(dto.Interest) ? "Gaming" : dto.Interest
            };

            _context.CustomerProfiles.Add(profile);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Thêm khách hàng mới thành công!", accountId = account.AccountId });
        }

        [HttpDelete("customers/{id}")]
        public async Task<IActionResult> DeleteCustomer(int id)
        {
            var account = await _context.Accounts.FindAsync(id);
            if (account == null) return NotFound(new { message = "Không tìm thấy khách hàng." });

            // Xóa dữ liệu liên quan để tránh xung đột khóa ngoại SQL Server
            var profiles = await _context.CustomerProfiles.Where(p => p.AccountId == id).ToListAsync();
            if (profiles.Any()) _context.CustomerProfiles.RemoveRange(profiles);

            var feedbacks = await _context.Feedbacks.Where(f => f.AccountId == id).ToListAsync();
            if (feedbacks.Any()) _context.Feedbacks.RemoveRange(feedbacks);

            var responses = await _context.SurveyResponses.Where(r => r.AccountId == id).ToListAsync();
            if (responses.Any()) _context.SurveyResponses.RemoveRange(responses);

            _context.Accounts.Remove(account);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa khách hàng thành công." });
        }

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
                    ProductImage = f.Product != null ? f.Product.ImageUrl : null,
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

        // 7. QUẢN LÝ KHẢO SÁT (CÓ THỜI HẠN + KHÓA/MỞ KHÓA + XÓA)
        [HttpGet("surveys")]
        public async Task<IActionResult> GetSurveys()
        {
            var now = DateTime.Now;
            int totalCustomerAccounts = await _context.Accounts
                .Include(a => a.Role)
                .CountAsync(a => a.Role != null && a.Role.RoleName == "Customer");

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
                    s.ExpiresAt,
                    IsExpired = s.ExpiresAt.HasValue && s.ExpiresAt.Value < now,
                    TotalCustomerAccounts = totalCustomerAccounts,
                    TotalResponses = _context.SurveyResponses.Count(r => r.SurveyId == s.SurveyId)
                })
                .ToListAsync();

            return Ok(surveys);
        }

        [HttpPost("surveys")]
        public async Task<IActionResult> CreateSurvey([FromBody] SurveyCreateDto dto)
        {
            DateTime? expiresAt = null;
            if (dto.DurationType == "Days" && dto.DurationDays.HasValue && dto.DurationDays.Value > 0)
            {
                expiresAt = DateTime.Now.AddDays(dto.DurationDays.Value);
            }
            else if (dto.DurationType == "Date" && dto.ExpiresAt.HasValue)
            {
                // Đặt hạn tới cuối ngày (23:59:59) của ngày được chọn
                expiresAt = dto.ExpiresAt.Value.Date.AddDays(1).AddSeconds(-1);
            }

            var survey = new Survey
            {
                Title = dto.Title,
                Description = dto.Description,
                TargetProduct = dto.TargetProduct,
                ExpectedPrice = dto.ExpectedPrice,
                CreatedAt = DateTime.Now,
                IsActive = true,
                ExpiresAt = expiresAt
            };

            _context.Surveys.Add(survey);
            await _context.SaveChangesAsync();

            int recipientCount = await _context.Accounts
                .Include(a => a.Role)
                .CountAsync(a => a.Role != null && a.Role.RoleName == "Customer" && a.IsActive);

            return Ok(new
            {
                message = $"Đã tạo bảng khảo sát và gửi đến {recipientCount} tài khoản khách hàng đang hoạt động!",
                surveyId = survey.SurveyId,
                recipientCount
            });
        }

        // API KHÓA / MỞ KHÓA KHẢO SÁT
        [HttpPut("surveys/{id}/toggle-lock")]
        public async Task<IActionResult> ToggleSurveyLock(int id)
        {
            var survey = await _context.Surveys.FindAsync(id);
            if (survey == null)
                return NotFound(new { message = "Không tìm thấy khảo sát!" });

            survey.IsActive = !survey.IsActive;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = survey.IsActive ? "Đã mở khóa khảo sát cho khách hàng tham gia!" : "Đã khóa khảo sát!",
                isActive = survey.IsActive
            });
        }

        [HttpDelete("surveys/{id}")]
        public async Task<IActionResult> DeleteSurvey(int id)
        {
            var survey = await _context.Surveys.FindAsync(id);
            if (survey == null)
                return NotFound(new { message = "Không tìm thấy bảng khảo sát cần xóa!" });

            var responses = await _context.SurveyResponses.Where(r => r.SurveyId == id).ToListAsync();
            if (responses.Any())
            {
                _context.SurveyResponses.RemoveRange(responses);
            }

            _context.Surveys.Remove(survey);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa bảng khảo sát thành công!" });
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

            var scoreDistribution = new
            {
                Score1 = responses.Count(r => r.Score == 1),
                Score2 = responses.Count(r => r.Score == 2),
                Score3 = responses.Count(r => r.Score == 3),
                Score4 = responses.Count(r => r.Score == 4),
                Score5 = responses.Count(r => r.Score == 5)
            };

            var detailResponses = responses.Select(r => new
            {
                r.ResponseId,
                r.AccountId,
                CustomerUsername = r.Account != null ? r.Account.Username : "khachhang",
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
                survey.Description,
                survey.TargetProduct,
                survey.ExpectedPrice,
                survey.CreatedAt,
                survey.ExpiresAt,
                survey.IsActive,
                totalResponses = total,
                averageScore = avgScore,
                intentStats,
                scoreDistribution,
                detailResponses
            });
        }
    }
}