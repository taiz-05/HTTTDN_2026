namespace HTTTDN.AdminApi.DTOs
{
    public class AccountCreateDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = "123456";
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public int RoleId { get; set; }
    }

    public class UpdateRoleDto
    {
        public int RoleId { get; set; }
    }
}