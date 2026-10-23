namespace HTTTDN.AdminApi.DTOs
{
    public class ProductSaveDto
    {
        public string ProductCode { get; set; } = string.Empty;
        public string ProductName { get; set; } = string.Empty;
        public int CategoryId { get; set; }
        public int SupplierId { get; set; }
        public decimal Price { get; set; }
        public decimal CostPrice { get; set; }
        public int StockQuantity { get; set; }
        public string Unit { get; set; } = "Cái";
        public string Status { get; set; } = "Đang bán";
    }
}