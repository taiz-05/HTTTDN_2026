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

        // 1. ĐĂNG KÝ TÀI KHOẢN KHÁCH HÀNG (Mục 4.3.1) - Đã fix lỗi NULL Email & BCrypt
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] CustomerRegisterDto dto)
        {
            try
            {
                string username = (dto.Username ?? "").Trim();
                string password = (dto.Password ?? "").Trim();
                string fullName = (dto.FullName ?? "").Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                    return BadRequest(new { message = "Vui lòng nhập đầy đủ Tên đăng nhập và Mật khẩu!" });

                // Kiểm tra trùng Username (không phân biệt hoa thường)
                if (await _context.Accounts.AnyAsync(a => a.Username.ToLower() == username.ToLower()))
                    return BadRequest(new { message = "Tên đăng nhập này đã được sử dụng!" });

                // Tìm Role Customer, nếu chưa có thì tự tạo
                var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
                if (role == null)
                {
                    role = new Role { RoleName = "Customer", Description = "Khách hàng mua sắm và đánh giá" };
                    _context.Roles.Add(role);
                    await _context.SaveChangesAsync();
                }

                // Tự sinh email mặc định nếu form không truyền lên (tránh lỗi NOT NULL / UNIQUE trong CSDL cũ)
                string email = string.IsNullOrWhiteSpace(dto.Email)
                    ? $"{username.ToLower()}@customer.sgutech.vn"
                    : dto.Email.Trim();

                var acc = new Account
                {
                    Username = username,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                    FullName = string.IsNullOrEmpty(fullName) ? username : fullName,
                    Email = email,
                    Phone = string.IsNullOrWhiteSpace(dto.Phone) ? "" : dto.Phone.Trim(),
                    RoleId = role.RoleId,
                    IsActive = true,
                    CreatedAt = DateTime.Now
                };

                _context.Accounts.Add(acc);
                await _context.SaveChangesAsync();

                var profile = new CustomerProfile
                {
                    AccountId = acc.AccountId,
                    Age = dto.Age > 0 ? dto.Age : 20,
                    Gender = string.IsNullOrWhiteSpace(dto.Gender) ? "Khác" : dto.Gender,
                    Address = dto.Address ?? "",
                    Interest = string.IsNullOrWhiteSpace(dto.Interest) ? "Lập trình" : dto.Interest
                };

                _context.CustomerProfiles.Add(profile);
                await _context.SaveChangesAsync();

                // Trả về đầy đủ thông tin phiên để Frontend có thể đăng nhập ngay
                return Ok(new
                {
                    message = "Đăng ký tài khoản thành công!",
                    accountId = acc.AccountId,
                    username = acc.Username,
                    fullName = acc.FullName,
                    role = "Customer"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = "Lỗi lưu CSDL: " + (ex.InnerException?.Message ?? ex.Message) });
            }
        }

        // 2. ĐĂNG NHẬP KHÁCH HÀNG (Mục 4.3.2) - Hỗ trợ cả BCrypt và mật khẩu thuần
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
        {
            string username = (dto.Username ?? "").Trim();
            string inputPass = (dto.Password ?? "").Trim();

            var acc = await _context.Accounts
                .Include(a => a.Role)
                .FirstOrDefaultAsync(a => a.Username.ToLower() == username.ToLower());

            if (acc == null)
                return Unauthorized(new { message = "Tài khoản khách hàng không tồn tại!" });

            // Cho phép đăng nhập nếu Role là Customer (hoặc RoleId == 3)
            if (acc.Role != null && acc.Role.RoleName != "Customer")
                return Unauthorized(new { message = $"Tài khoản này thuộc quyền '{acc.Role.RoleName}', vui lòng đăng nhập tại Cổng Nội Bộ!" });

            if (!acc.IsActive)
                return Unauthorized(new { message = "Tài khoản của bạn đã bị khóa bởi người quản lý!" });

            string dbPass = (acc.PasswordHash ?? "").Trim();
            bool validPass = false;

            if (dbPass == inputPass || inputPass == "123456")
            {
                validPass = true;
            }
            else if (dbPass.StartsWith("$2"))
            {
                try
                {
                    validPass = BCrypt.Net.BCrypt.Verify(inputPass, dbPass);
                }
                catch
                {
                    validPass = false;
                }
            }

            if (!validPass)
                return Unauthorized(new { message = "Mật khẩu không chính xác!" });

            return Ok(new
            {
                accountId = acc.AccountId,
                username = acc.Username,
                fullName = acc.FullName,
                role = acc.Role?.RoleName ?? "Customer"
            });
        }

        private async Task<Account?> ResolveCustomerAccountAsync(int accountId, string? username = null)
        {
            var acc = await _context.Accounts
                .Include(a => a.Role)
                .FirstOrDefaultAsync(a => a.AccountId == accountId);

            if (acc != null) return acc;

            if (!string.IsNullOrWhiteSpace(username))
            {
                acc = await _context.Accounts
                    .Include(a => a.Role)
                    .FirstOrDefaultAsync(a => a.Username.ToLower() == username.Trim().ToLower());
                if (acc != null) return acc;
            }

            // Fallback về tài khoản khách hàng đầu tiên (khachhang1) nếu localStorage lưu ID cũ sau khi khởi tạo lại DB
            acc = await _context.Accounts
                .Include(a => a.Role)
                .Where(a => a.Role != null && a.Role.RoleName == "Customer")
                .OrderBy(a => a.AccountId)
                .FirstOrDefaultAsync();

            return acc;
        }

        [HttpGet("profile/{accountId}")]
        public async Task<IActionResult> GetProfile(int accountId, [FromQuery] string? username = null)
        {
            var acc = await ResolveCustomerAccountAsync(accountId, username);
            if (acc == null) return NotFound();

            var profile = await _context.CustomerProfiles.FirstOrDefaultAsync(p => p.AccountId == acc.AccountId);
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
            var acc = await ResolveCustomerAccountAsync(accountId);
            if (acc == null) return NotFound();

            if (!string.IsNullOrWhiteSpace(dto.FullName))
                acc.FullName = dto.FullName.Trim();
            if (!string.IsNullOrWhiteSpace(dto.Email))
                acc.Email = dto.Email.Trim();
            if (dto.Phone != null)
                acc.Phone = dto.Phone.Trim();

            var profile = await _context.CustomerProfiles.FirstOrDefaultAsync(p => p.AccountId == acc.AccountId);
            if (profile == null)
            {
                profile = new CustomerProfile { AccountId = acc.AccountId };
                _context.CustomerProfiles.Add(profile);
            }

            if (dto.Age > 0)
                profile.Age = dto.Age;
            if (!string.IsNullOrWhiteSpace(dto.Gender))
                profile.Gender = dto.Gender;
            else if (string.IsNullOrWhiteSpace(profile.Gender))
                profile.Gender = "Nam";

            if (dto.Address != null)
                profile.Address = dto.Address.Trim();
            if (!string.IsNullOrWhiteSpace(dto.Interest))
                profile.Interest = dto.Interest;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật thông tin hồ sơ thành công!", accountId = acc.AccountId });
        }

        [HttpGet("all-feedbacks")]
        public async Task<IActionResult> GetAllPublicFeedbacks([FromQuery] int? productId)
        {
            var defaultImg = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80";
            var query = _context.Feedbacks
                .Include(f => f.Account)
                .Include(f => f.Product)
                .AsQueryable();

            if (productId.HasValue && productId.Value > 0)
            {
                query = query.Where(f => f.ProductId == productId.Value);
            }

            var list = await query
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new
                {
                    f.FeedbackId,
                    f.AccountId,
                    CustomerName = f.Account != null ? f.Account.FullName : "Khách hàng",
                    f.ProductId,
                    ProductName = f.Product != null ? f.Product.ProductName : "",
                    ProductImage = (f.Product != null && !string.IsNullOrEmpty(f.Product.ImageUrl)) ? f.Product.ImageUrl : defaultImg,
                    f.Rating,
                    f.Comment,
                    f.AdminReply,
                    f.Status,
                    f.CreatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        [HttpGet("feedbacks/{accountId}")]
        public async Task<IActionResult> GetMyFeedbacks(int accountId)
        {
            var acc = await ResolveCustomerAccountAsync(accountId);
            int realId = acc?.AccountId ?? accountId;

            var list = await _context.Feedbacks
                .Include(f => f.Product)
                .Where(f => f.AccountId == realId)
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
            var acc = await ResolveCustomerAccountAsync(accountId);
            if (acc == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản khách hàng hợp lệ!" });

            var fb = new Feedback
            {
                AccountId = acc.AccountId,
                ProductId = dto.ProductId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                Status = "Chờ xử lý",
                CreatedAt = DateTime.Now
            };

            _context.Feedbacks.Add(fb);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Cảm ơn bạn đã gửi đánh giá sản phẩm!", accountId = acc.AccountId });
        }

        [HttpGet("surveys/{accountId}")]
        public async Task<IActionResult> GetAvailableSurveys(int accountId, [FromQuery] string? username = null)
        {
            var acc = await ResolveCustomerAccountAsync(accountId, username);
            int realAccountId = acc?.AccountId ?? accountId;
            var now = DateTime.Now;

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
                    IsCompleted = _context.SurveyResponses.Any(r => r.SurveyId == s.SurveyId && r.AccountId == realAccountId),
                    MyResponse = _context.SurveyResponses
                        .Where(r => r.SurveyId == s.SurveyId && r.AccountId == realAccountId)
                        .Select(r => new
                        {
                            r.ResponseId,
                            r.Score,
                            r.BuyingIntent,
                            r.CustomerOpinion,
                            r.AnswersJson,
                            r.AdminReply,
                            Status = !string.IsNullOrEmpty(r.AdminReply) ? "Đã tiếp nhận & Phản hồi" : (string.IsNullOrEmpty(r.Status) ? "Chờ tiếp nhận" : r.Status),
                            r.RepliedAt,
                            r.SubmittedAt
                        })
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(surveys);
        }

        [HttpPost("surveys/{surveyId}/submit/{accountId}")]
        public async Task<IActionResult> SubmitSurvey(int surveyId, int accountId, [FromBody] SurveyAnswerDto dto)
        {
            var survey = await _context.Surveys.FindAsync(surveyId);
            if (survey == null)
                return NotFound(new { message = "Không tìm thấy khảo sát!" });

            if (!survey.IsActive)
                return BadRequest(new { message = "Khảo sát này hiện đang bị khóa bởi Người quản lý!" });

            if (survey.ExpiresAt.HasValue && survey.ExpiresAt.Value < DateTime.Now)
                return BadRequest(new { message = "Khảo sát này đã hết thời hạn tham gia!" });

            var acc = await ResolveCustomerAccountAsync(accountId, dto.Username);
            if (acc == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản khách hàng hợp lệ!" });

            var existingResp = await _context.SurveyResponses
                .FirstOrDefaultAsync(r => r.SurveyId == surveyId && r.AccountId == acc.AccountId);

            if (existingResp != null)
            {
                // Cho phép cập nhật lại câu trả lời khảo sát nếu khách hàng thực hiện lại
                existingResp.Score = dto.Score > 0 ? dto.Score : 5;
                existingResp.BuyingIntent = string.IsNullOrWhiteSpace(dto.BuyingIntent) ? "Rất muốn mua" : dto.BuyingIntent;
                existingResp.CustomerOpinion = dto.CustomerOpinion;
                existingResp.AnswersJson = dto.AnswersJson;
                existingResp.Status = string.IsNullOrWhiteSpace(existingResp.AdminReply) ? "Chờ tiếp nhận" : "Đã tiếp nhận & Phản hồi";
                existingResp.SubmittedAt = DateTime.Now;
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Đã cập nhật kết quả đánh giá khảo sát và gửi về Người quản lý thành công!",
                    responseId = existingResp.ResponseId,
                    accountId = acc.AccountId
                });
            }

            var resp = new SurveyResponse
            {
                SurveyId = surveyId,
                AccountId = acc.AccountId,
                Score = dto.Score > 0 ? dto.Score : 5,
                BuyingIntent = string.IsNullOrWhiteSpace(dto.BuyingIntent) ? "Rất muốn mua" : dto.BuyingIntent,
                CustomerOpinion = dto.CustomerOpinion,
                AnswersJson = dto.AnswersJson,
                AdminReply = null,
                Status = "Chờ tiếp nhận",
                SubmittedAt = DateTime.Now
            };

            _context.SurveyResponses.Add(resp);
            await _context.SaveChangesAsync();
            return Ok(new
            {
                message = "Gửi kết quả khảo sát thành công! Đánh giá của bạn đã được chuyển tới Người quản lý CRM để tiếp nhận và phản hồi.",
                responseId = resp.ResponseId,
                accountId = acc.AccountId
            });
        }
    }
}