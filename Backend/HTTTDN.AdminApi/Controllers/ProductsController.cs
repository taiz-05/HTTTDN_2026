using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/products")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly AppDbContext _context;
        public ProductsController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetProducts(
            [FromQuery] string? keyword,
            [FromQuery] int? categoryId,
            [FromQuery] int? supplierId,
            [FromQuery] decimal? minPrice,
            [FromQuery] decimal? maxPrice,
            [FromQuery] string? status,
            [FromQuery] string? sortBy,
            [FromQuery] string? sort)
        {
            var query = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(keyword))
                query = query.Where(p => p.ProductName.Contains(keyword) || p.ProductCode.Contains(keyword));

            if (categoryId.HasValue && categoryId > 0)
                query = query.Where(p => p.CategoryId == categoryId);

            if (supplierId.HasValue && supplierId > 0)
                query = query.Where(p => p.SupplierId == supplierId);

            if (minPrice.HasValue)
                query = query.Where(p => p.Price >= minPrice.Value);

            if (maxPrice.HasValue)
                query = query.Where(p => p.Price <= maxPrice.Value);

            if (!string.IsNullOrWhiteSpace(status))
                query = query.Where(p => p.Status == status);

            var activeSort = !string.IsNullOrWhiteSpace(sortBy) ? sortBy : sort;
            query = activeSort switch
            {
                "price_asc" => query.OrderBy(p => p.Price),
                "price_desc" => query.OrderByDescending(p => p.Price),
                "name_asc" => query.OrderBy(p => p.ProductName),
                "stock_desc" => query.OrderByDescending(p => p.StockQuantity),
                _ => query.OrderByDescending(p => p.ProductId)
            };

            var defaultImg = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80";

            var result = await query.Select(p => new
            {
                p.ProductId,
                p.ProductCode,
                p.ProductName,
                p.CategoryId,
                CategoryName = p.Category != null ? p.Category.CategoryName : "",
                p.SupplierId,
                SupplierName = p.Supplier != null ? p.Supplier.SupplierName : "",
                p.Price,
                p.CostPrice,
                p.StockQuantity,
                p.Unit,
                p.Status,
                ImageUrl = string.IsNullOrEmpty(p.ImageUrl) ? defaultImg : p.ImageUrl,
                ReviewCount = _context.Feedbacks.Count(f => f.ProductId == p.ProductId),
                TotalReviews = _context.Feedbacks.Count(f => f.ProductId == p.ProductId),
                AvgRating = _context.Feedbacks.Where(f => f.ProductId == p.ProductId).Select(f => (double?)f.Rating).Average() ?? 5.0,
                AverageRating = _context.Feedbacks.Where(f => f.ProductId == p.ProductId).Select(f => (double?)f.Rating).Average() ?? 5.0
            }).ToListAsync();

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProductSaveDto dto)
        {
            if (await _context.Products.AnyAsync(p => p.ProductCode == dto.ProductCode.Trim()))
                return BadRequest(new { message = "Mã sản phẩm đã tồn tại!" });

            var prod = new Product
            {
                ProductCode = dto.ProductCode.Trim(),
                ProductName = dto.ProductName.Trim(),
                CategoryId = dto.CategoryId,
                SupplierId = dto.SupplierId,
                Price = dto.Price,
                CostPrice = dto.CostPrice > 0 ? dto.CostPrice : dto.Price * 0.8m,
                StockQuantity = dto.StockQuantity,
                Unit = string.IsNullOrWhiteSpace(dto.Unit) ? "Cái" : dto.Unit,
                Status = string.IsNullOrWhiteSpace(dto.Status)
                    ? (dto.StockQuantity > 0 ? "Đang bán" : "Hết hàng")
                    : dto.Status,
                ImageUrl = string.IsNullOrWhiteSpace(dto.ImageUrl)
                    ? "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&auto=format&fit=crop&q=80"
                    : dto.ImageUrl.Trim()
            };
            _context.Products.Add(prod);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Thêm sản phẩm thành công!", product = prod });
        }

        // API SỬA THÔNG TIN SẢN PHẨM
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ProductSaveDto dto)
        {
            var prod = await _context.Products.FindAsync(id);
            if (prod == null)
                return NotFound(new { message = "Không tìm thấy sản phẩm cần sửa!" });

            if (await _context.Products.AnyAsync(p => p.ProductCode == dto.ProductCode.Trim() && p.ProductId != id))
                return BadRequest(new { message = "Mã sản phẩm này đã trùng với sản phẩm khác!" });

            prod.ProductCode = dto.ProductCode.Trim();
            prod.ProductName = dto.ProductName.Trim();
            prod.CategoryId = dto.CategoryId;
            prod.SupplierId = dto.SupplierId;
            prod.Price = dto.Price;
            prod.CostPrice = dto.CostPrice > 0 ? dto.CostPrice : dto.Price * 0.8m;
            prod.StockQuantity = dto.StockQuantity;
            prod.Status = dto.Status;

            if (!string.IsNullOrWhiteSpace(dto.ImageUrl))
            {
                prod.ImageUrl = dto.ImageUrl.Trim();
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật thông tin sản phẩm thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var prod = await _context.Products.FindAsync(id);
            if (prod == null) return NotFound(new { message = "Không tìm thấy sản phẩm." });

            // Xóa các đánh giá liên quan trước khi xóa sản phẩm để tránh lỗi khóa ngoại
            var relatedFeedbacks = await _context.Feedbacks.Where(f => f.ProductId == id).ToListAsync();
            if (relatedFeedbacks.Any())
            {
                _context.Feedbacks.RemoveRange(relatedFeedbacks);
            }

            _context.Products.Remove(prod);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa sản phẩm thành công." });
        }
    }
}