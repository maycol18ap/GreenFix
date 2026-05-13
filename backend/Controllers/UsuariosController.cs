using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.Models;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly GreenFixDbContext _context;

    public UsuariosController(GreenFixDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var usuarios = await _context.Usuarios.OrderBy(u => u.UsuarioID).ToListAsync();
        return Ok(usuarios);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var usuario = await _context.Usuarios.FindAsync(id);
        if (usuario == null) return NotFound();
        return Ok(usuario);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Usuario usuario)
    {
        if (usuario == null) return BadRequest();
        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = usuario.UsuarioID }, usuario);
    }
}
