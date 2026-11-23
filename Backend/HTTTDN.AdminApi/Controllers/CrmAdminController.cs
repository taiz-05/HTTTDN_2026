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

        // 7. QUẢN LÝ KHẢO SÁT ĐA CÂU HỎI & ĐA YÊU CẦU (CÓ THỜI HẠN + KHÓA/MỞ KHÓA + XÓA + TIẾP NHẬN PHẢN HỒI)
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
                    s.RequirementsJson,
                    s.QuestionsJson,
                    IsExpired = s.ExpiresAt.HasValue && s.ExpiresAt.Value < now,
                    TotalCustomerAccounts = totalCustomerAccounts,
                    TotalResponses = _context.SurveyResponses.Count(r => r.SurveyId == s.SurveyId),
                    PendingResponses = _context.SurveyResponses.Count(r => r.SurveyId == s.SurveyId && (r.AdminReply == null || r.AdminReply == "")),
                    AnsweredResponses = _context.SurveyResponses.Count(r => r.SurveyId == s.SurveyId && r.AdminReply != null && r.AdminReply != "")
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
                expiresAt = dto.ExpiresAt.Value.Date.AddDays(1).AddSeconds(-1);
            }

            string defaultReqs = @"[""Yêu cầu đánh giá mức độ quan tâm & thiết kế sản phẩm"",""Yêu cầu thẩm định mức giá dự kiến & ngân sách chi trả"",""Yêu cầu khảo sát cấu hình kỹ thuật & tính năng ưu tiên"",""Yêu cầu xác định kế hoạch mua sắm & chính sách hậu mãi""]";
            string defaultQs = @"[
                {""id"":1,""requirement"":""Yêu cầu đánh giá mức độ quan tâm"",""question"":""Mức độ quan tâm và hào hứng của bạn đối với sản phẩm mới này?"",""type"":""rating"",""required"":true,""options"":[""1 - Rất thờ ơ"",""2 - Ít quan tâm"",""3 - Bình thường"",""4 - Khá quan tâm"",""5 - Rất hào hứng""]},
                {""id"":2,""requirement"":""Yêu cầu thẩm định mức giá dự kiến"",""question"":""Bạn đánh giá thế nào về mức giá dự kiến mở bán so với công nghệ mang lại?"",""type"":""single"",""required"":true,""options"":[""Giá rất hợp lý / Đáng đầu tư"",""Mức giá hơi cao nhưng chấp nhận được"",""Mức giá quá đắt / Cần giảm thêm"",""Chưa phù hợp với ngân sách""]},
                {""id"":3,""requirement"":""Yêu cầu khảo sát tính năng & cấu hình"",""question"":""Những tiêu chí kỹ thuật & tính năng nào bạn yêu cầu bắt buộc phải có trên sản phẩm?"",""type"":""multi"",""required"":true,""options"":[""Hiệu năng mạnh mẽ vượt trội"",""Thời lượng pin bền bỉ & Sạc nhanh"",""Thiết kế mỏng nhẹ cao cấp"",""Tích hợp công nghệ AI thông minh"",""Màn hình chuẩn màu độ phân giải cao""]},
                {""id"":4,""requirement"":""Yêu cầu xác định kế hoạch mua sắm"",""question"":""Kế hoạch và ý định mua sắm của bạn khi sản phẩm chính thức mở bán?"",""type"":""single"",""required"":true,""options"":[""Rất muốn mua (Đặt trước Pre-order ngay)"",""Đang cân nhắc (Chờ xem đánh giá thực tế)"",""Đang cân nhắc (Đợi đợt khuyến mãi giảm giá)"",""Không mua (Chưa có nhu cầu)""]},
                {""id"":5,""requirement"":""Yêu cầu đề xuất mức giá & góp ý riêng"",""question"":""Mức giá bạn sẵn sàng chi trả và các yêu cầu / góp ý chi tiết khác cho sản phẩm:"",""type"":""text"",""required"":false,""options"":[]}
            ]";

            var survey = new Survey
            {
                Title = dto.Title,
                Description = dto.Description,
                TargetProduct = dto.TargetProduct,
                ExpectedPrice = dto.ExpectedPrice,
                CreatedAt = DateTime.Now,
                IsActive = true,
                ExpiresAt = expiresAt,
                RequirementsJson = string.IsNullOrWhiteSpace(dto.RequirementsJson) ? defaultReqs : dto.RequirementsJson,
                QuestionsJson = string.IsNullOrWhiteSpace(dto.QuestionsJson) ? defaultQs : dto.QuestionsJson
            };

            _context.Surveys.Add(survey);
            await _context.SaveChangesAsync();

            int recipientCount = await _context.Accounts
                .Include(a => a.Role)
                .CountAsync(a => a.Role != null && a.Role.RoleName == "Customer" && a.IsActive);

            return Ok(new
            {
                message = $"Đã tạo chiến dịch khảo sát đa câu hỏi và gửi đến {recipientCount} tài khoản khách hàng đang hoạt động!",
                surveyId = survey.SurveyId,
                recipientCount
            });
        }

        // API LẤY TOÀN BỘ PHẢN HỒI / ĐÁNH GIÁ KHẢO SÁT CỦA KHÁCH HÀNG ĐỂ NGƯỜI QUẢN LÝ TIẾP NHẬN & TRẢ LỜI
        [HttpGet("survey-responses")]
        public async Task<IActionResult> GetAllSurveyResponses([FromQuery] int? surveyId)
        {
            var query = _context.SurveyResponses
                .Include(r => r.Account)
                .Include(r => r.Survey)
                .AsQueryable();

            if (surveyId.HasValue && surveyId.Value > 0)
            {
                query = query.Where(r => r.SurveyId == surveyId.Value);
            }

            var list = await query
                .OrderByDescending(r => r.SubmittedAt)
                .Select(r => new
                {
                    r.ResponseId,
                    r.SurveyId,
                    SurveyTitle = r.Survey != null ? r.Survey.Title : "Chiến dịch khảo sát",
                    TargetProduct = r.Survey != null ? r.Survey.TargetProduct : "Sản phẩm khảo sát",
                    ExpectedPrice = r.Survey != null ? r.Survey.ExpectedPrice : 0,
                    r.AccountId,
                    CustomerUsername = r.Account != null ? r.Account.Username : "khachhang",
                    CustomerName = r.Account != null ? r.Account.FullName : "Khách hàng",
                    r.Score,
                    r.BuyingIntent,
                    r.CustomerOpinion,
                    r.AnswersJson,
                    r.AdminReply,
                    Status = !string.IsNullOrEmpty(r.AdminReply) ? "Đã tiếp nhận & Phản hồi" : (string.IsNullOrEmpty(r.Status) ? "Chờ tiếp nhận" : r.Status),
                    r.RepliedAt,
                    r.SubmittedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        // API NGƯỜI QUẢN LÝ TIẾP NHẬN & GỬI PHẢN HỒI CHO ĐÁNH GIÁ KHẢO SÁT CỦA KHÁCH HÀNG
        [HttpPut("survey-responses/{responseId}/reply")]
        public async Task<IActionResult> ReplyToSurveyResponse(int responseId, [FromBody] SurveyResponseReplyDto dto)
        {
            var resp = await _context.SurveyResponses.FindAsync(responseId);
            if (resp == null)
                return NotFound(new { message = "Không tìm thấy phiếu đánh giá khảo sát của khách hàng!" });

            resp.AdminReply = (dto.AdminReply ?? "").Trim();
            resp.Status = string.IsNullOrEmpty(resp.AdminReply) ? "Chờ tiếp nhận" : "Đã tiếp nhận & Phản hồi";
            resp.RepliedAt = DateTime.Now;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Đã tiếp nhận và gửi phản hồi cho bài đánh giá khảo sát của khách hàng!",
                responseId = resp.ResponseId,
                status = resp.Status,
                adminReply = resp.AdminReply,
                repliedAt = resp.RepliedAt
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

        private static string ClassifyBuyingIntent(string? intent)
        {
            string s = (intent ?? "").ToLowerInvariant();
            if (s.Contains("rất muốn") || s.Contains("đặt trước") || s.Contains("pre-order") || s.Contains("mua ngay"))
                return "WantToBuy";
            if (s.Contains("không mua") || s.Contains("chưa có nhu cầu") || s.Contains("chưa có kế hoạch") || s.Contains("từ chối"))
                return "NotBuying";
            return "Considering";
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
                WantToBuy = responses.Count(r => ClassifyBuyingIntent(r.BuyingIntent) == "WantToBuy"),
                Considering = responses.Count(r => ClassifyBuyingIntent(r.BuyingIntent) == "Considering"),
                NotBuying = responses.Count(r => ClassifyBuyingIntent(r.BuyingIntent) == "NotBuying")
            };

            var scoreDistribution = new
            {
                Score1 = responses.Count(r => r.Score == 1),
                Score2 = responses.Count(r => r.Score == 2),
                Score3 = responses.Count(r => r.Score == 3),
                Score4 = responses.Count(r => r.Score == 4),
                Score5 = responses.Count(r => r.Score == 5)
            };

            int answeredCount = responses.Count(r => !string.IsNullOrWhiteSpace(r.AdminReply));
            int pendingReplyCount = total - answeredCount;

            var detailResponses = responses.Select(r => new
            {
                r.ResponseId,
                r.SurveyId,
                SurveyTitle = survey.Title,
                TargetProduct = survey.TargetProduct,
                r.AccountId,
                CustomerUsername = r.Account != null ? r.Account.Username : "khachhang",
                CustomerName = r.Account != null ? r.Account.FullName : "Khách hàng",
                r.Score,
                r.BuyingIntent,
                r.CustomerOpinion,
                r.AnswersJson,
                r.AdminReply,
                Status = !string.IsNullOrWhiteSpace(r.AdminReply) ? "Đã tiếp nhận & Phản hồi" : "Chờ tiếp nhận",
                r.RepliedAt,
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
                survey.RequirementsJson,
                survey.QuestionsJson,
                totalResponses = total,
                answeredCount,
                pendingReplyCount,
                averageScore = avgScore,
                intentStats,
                scoreDistribution,
                detailResponses
            });
        }
    }
}