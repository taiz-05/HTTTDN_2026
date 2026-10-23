using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HTTTDN.AdminApi.Models
{
    public class CustomerProfile
    {
        [Key]
        public int ProfileId { get; set; }
        public int AccountId { get; set; }
        [ForeignKey("AccountId")]
        public Account? Account { get; set; }
        public int Age { get; set; }
        public string? Gender { get; set; }
        public string? Address { get; set; }
        public string? Interest { get; set; }
    }

    public class Feedback
    {
        [Key]
        public int FeedbackId { get; set; }
        public int AccountId { get; set; }
        [ForeignKey("AccountId")]
        public Account? Account { get; set; }
        public int ProductId { get; set; }
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
        public string? AdminReply { get; set; }
        public string Status { get; set; } = "Chờ xử lý";
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }

    public class Survey
    {
        [Key]
        public int SurveyId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string TargetProduct { get; set; } = string.Empty;
        [Column(TypeName = "decimal(18,2)")]
        public decimal ExpectedPrice { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public bool IsActive { get; set; } = true;
    }

    public class SurveyResponse
    {
        [Key]
        public int ResponseId { get; set; }
        public int SurveyId { get; set; }
        [ForeignKey("SurveyId")]
        public Survey? Survey { get; set; }
        public int AccountId { get; set; }
        [ForeignKey("AccountId")]
        public Account? Account { get; set; }
        public int Score { get; set; }
        public string BuyingIntent { get; set; } = string.Empty;
        public string? CustomerOpinion { get; set; }
        public DateTime SubmittedAt { get; set; } = DateTime.Now;
    }
}