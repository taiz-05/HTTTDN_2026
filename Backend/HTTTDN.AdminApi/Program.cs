using HTTTDN.AdminApi.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var customUrl = args.FirstOrDefault(a => a.StartsWith("--urls="))?.Substring(7) ?? "http://localhost:5000";
builder.WebHost.UseUrls(customUrl);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var useSqlite = builder.Configuration.GetValue<bool>("UseSqlite", true);

if (useSqlite)
{
    var sqliteConn = builder.Configuration.GetConnectionString("SqliteConnection") ?? "Data Source=htttdn.db";
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseSqlite(sqliteConn));
}
else
{
    var sqlServerConn = builder.Configuration.GetConnectionString("DefaultConnection");
    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseSqlServer(sqlServerConn));
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Tự động khởi tạo cấu trúc CSDL và nạp dữ liệu mẫu
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        DbInitializer.Initialize(context);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[Lỗi Khởi tạo CSDL]: {ex.Message}");
    }
}

if (args.Contains("--seed-only"))
{
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var rNames = string.Join(", ", context.Roles.Select(r => r.RoleName));
        Console.WriteLine($"[ROLES IN DB]: {rNames}");
        Console.WriteLine($"[ACCOUNTS IN DB]: {context.Accounts.Count()} accounts.");
        Console.WriteLine($"[SURVEYS IN DB]: {context.Surveys.Count()} surveys.");
        Console.WriteLine($"[SURVEY RESPONSES IN DB]: {context.SurveyResponses.Count()} responses.");
    }
    Console.WriteLine("[DB SEED SUCCESS]: SQLite database initialized with 3 roles: Admin, Manager, Customer.");
    return;
}

if (args.Contains("--verify-survey-flow"))
{
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var crmCtrl = new HTTTDN.AdminApi.Controllers.CrmAdminController(context);
        var cusCtrl = new HTTTDN.AdminApi.Controllers.CustomerPortalController(context);

        var createRes = await crmCtrl.CreateSurvey(new HTTTDN.AdminApi.DTOs.SurveyCreateDto
        {
            Title = "Khảo sát Test Đa Câu Hỏi & Đa Yêu Cầu",
            TargetProduct = "Laptop SGU AI Pro 2026",
            ExpectedPrice = 29990000,
            Description = "Khảo sát 4 yêu cầu và 6 câu hỏi",
            DurationType = "Days",
            DurationDays = 14
        }) as Microsoft.AspNetCore.Mvc.OkObjectResult;

        var newestSv = context.Surveys.OrderByDescending(s => s.SurveyId).First();
        Console.WriteLine($"[STEP 1 - CREATE MULTI-Q SURVEY]: SurveyId={newestSv.SurveyId}, HasQuestions={!string.IsNullOrEmpty(newestSv.QuestionsJson)}, HasReqs={!string.IsNullOrEmpty(newestSv.RequirementsJson)}");

        await cusCtrl.SubmitSurvey(newestSv.SurveyId, 999, new HTTTDN.AdminApi.DTOs.SurveyAnswerDto
        {
            Score = 5,
            BuyingIntent = "Rất muốn mua (Đặt trước Pre-order ngay)",
            CustomerOpinion = "[Đánh giá giá: Giá rất hợp lý] [Tiêu chí: Chip AI NPU, Màn OLED 120Hz] [Góp ý: Rất mong sớm mở bán!]",
            AnswersJson = @"[{""questionId"":1,""requirement"":""Yêu cầu mức độ quan tâm"",""question"":""Mức độ quan tâm?"",""type"":""rating"",""answer"":""5 / 5 điểm""}]",
            Username = "khachhang1"
        });

        var newestResp = context.SurveyResponses.OrderByDescending(r => r.ResponseId).First(r => r.SurveyId == newestSv.SurveyId);
        Console.WriteLine($"[STEP 2 - CUSTOMER SUBMIT]: ResponseId={newestResp.ResponseId}, AccountId={newestResp.AccountId}, Status={newestResp.Status}");

        await crmCtrl.ReplyToSurveyResponse(newestResp.ResponseId, new HTTTDN.AdminApi.DTOs.SurveyResponseReplyDto
        {
            AdminReply = "Cảm ơn bạn An đã đánh giá! Quản lý CRM xác nhận tặng kèm voucher 2 triệu khi Pre-order."
        });

        var updatedResp = context.SurveyResponses.Find(newestResp.ResponseId)!;
        Console.WriteLine($"[STEP 3 - MANAGER REPLY]: Status={updatedResp.Status} | AdminReply={updatedResp.AdminReply}");

        await crmCtrl.DeleteSurvey(newestSv.SurveyId);
        Console.WriteLine($"[STEP 4 - CLEANUP]: Deleted test survey #{newestSv.SurveyId}. Total Surveys={context.Surveys.Count()}, Total Responses={context.SurveyResponses.Count()}");
    }
    return;
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();
