using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.Models;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InversionesController : ControllerBase
{
    private readonly GreenFixDbContext _context;

    public InversionesController(GreenFixDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var inversiones = await _context.Inversiones.OrderBy(i => i.InversionID).ToListAsync();
        return Ok(inversiones);
    }

    [HttpGet("proyecto/{proyectoId}")]
    public async Task<IActionResult> GetByProyecto(int proyectoId)
    {
        var inversiones = await _context.Inversiones.Where(i => i.ProyectoID == proyectoId).ToListAsync();
        return Ok(inversiones);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Inversion inversion)
    {
        if (inversion == null) return BadRequest();
        _context.Inversiones.Add(inversion);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetAll), new { id = inversion.InversionID }, inversion);
    }
}
