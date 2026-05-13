namespace backend.Models;

public class Proyecto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public decimal MontoObjetivo { get; set; }
    public decimal MontoActual { get; set; }
    public string ContractAddress { get; set; } = string.Empty;
    public string Estado { get; set; } = "Activo";
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    public DateTime? FechaFinalizacion { get; set; }
    public int EmprendedorId { get; set; }
}
