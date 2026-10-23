namespace HTTTDN.AdminApi.DTOs
{
    public class CustomerRegisterDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int Age { get; set; } = 20;
        public string? Gender { get; set; } = "Khác";
        public string? Address { get; set; }
        public string? Interest { get; set; } = "Văn phòng";
    }

    public class CustomerUpdateProfileDto
    {
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int Age { get; set; }
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public string? Interest { get; set; }
    }

    public class FeedbackCreateDto
    {
        public int ProductId { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
    }

    public class FeedbackReplyDto
    {
        public string AdminReply { get; set; } = string.Empty;
    }

    public class SurveyCreateDto
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string TargetProduct { get; set; } = string.Empty;
        public decimal ExpectedPrice { get; set; }
    }

    public class SurveyAnswerDto
    {
        public int Score { get; set; }
        public string BuyingIntent { get; set; } = string.Empty;
        public string? CustomerOpinion { get; set; }
    }
}