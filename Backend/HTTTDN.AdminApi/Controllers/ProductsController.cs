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
            [FromQuery] string? sortBy)
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

            query = sortBy switch
            {
                "price_asc" => query.OrderBy(p => p.Price),
                "price_desc" => query.OrderByDescending(p => p.Price),
                "name_asc" => query.OrderBy(p => p.ProductName),
                "stock_desc" => query.OrderByDescending(p => p.StockQuantity),
                _ => query.OrderByDescending(p => p.ProductId)
            };

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
                p.Status
            }).ToListAsync();

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ProductSaveDto dto)
        {
            var prod = new Product
            {
                ProductCode = dto.ProductCode,
                ProductName = dto.ProductName,
                CategoryId = dto.CategoryId,
                SupplierId = dto.SupplierId,
                Price = dto.Price,
                CostPrice = dto.CostPrice,
                StockQuantity = dto.StockQuantity,
                Unit = dto.Unit,
                Status = dto.Status
            };
            _context.Products.Add(prod);
            await _context.SaveChangesAsync();
            return Ok(prod);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var prod = await _context.Products.FindAsync(id);
            if (prod == null) return NotFound();
            _context.Products.Remove(prod);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa sản phẩm." });
        }
    }
}