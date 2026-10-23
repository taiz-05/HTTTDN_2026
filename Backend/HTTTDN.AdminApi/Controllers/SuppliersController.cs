using HTTTDN.AdminApi.Data;
using HTTTDN.AdminApi.DTOs;
using HTTTDN.AdminApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HTTTDN.AdminApi.Controllers
{
    [Route("api/admin/suppliers")]
    [ApiController]
    public class SuppliersController : ControllerBase
    {
        private readonly AppDbContext _context;
        public SuppliersController(AppDbContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] string? keyword)
        {
            var query = _context.Suppliers.AsQueryable();
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(s => s.SupplierName.Contains(keyword) || s.SupplierCode.Contains(keyword));
            }
            return Ok(await query.OrderByDescending(s => s.SupplierId).ToListAsync());
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] SupplierSaveDto dto)
        {
            var sup = new Supplier
            {
                SupplierCode = dto.SupplierCode,
                SupplierName = dto.SupplierName,
                ContactName = dto.ContactName,
                Phone = dto.Phone,
                Email = dto.Email,
                Address = dto.Address
            };
            _context.Suppliers.Add(sup);
            await _context.SaveChangesAsync();
            return Ok(sup);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var sup = await _context.Suppliers.FindAsync(id);
            if (sup == null) return NotFound();
            _context.Suppliers.Remove(sup);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa nhà cung cấp." });
        }
    }
}