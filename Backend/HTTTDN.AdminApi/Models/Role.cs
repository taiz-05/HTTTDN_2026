using System.ComponentModel.DataAnnotations;

namespace HTTTDN.AdminApi.Models
{
    public class Role
    {
        [Key]
        public int RoleId { get; set; }
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }
    }
}