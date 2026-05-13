using Microsoft.AspNetCore.Mvc;
using backend.Data;
using System.Threading.Tasks;

namespace backend.Controllers
{
    [ApiController]
    public class HelloController : ControllerBase
    {
        private readonly GreenFixDbContext _context;

        public HelloController(GreenFixDbContext context)
        {
            _context = context;
        }

        [HttpGet("/")]
        public async Task<IActionResult> Get()
        {
            bool dbConnected = false;
            try
            {
                dbConnected = await _context.Database.CanConnectAsync();
            }
            catch
            {
                dbConnected = false;
            }

            return Ok(new { message = "Hola Mundo", databaseConnected = dbConnected });
        }
    }
}
