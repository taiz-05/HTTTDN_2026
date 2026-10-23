using System.ComponentModel.DataAnnotations;

namespace HTTTDN.AdminApi.Models
{
    public class Category
    {
        [Key]
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
    }
}