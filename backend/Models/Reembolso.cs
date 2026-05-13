using System;

namespace backend.Models;

public class Reembolso
{
    public int ReembolsoID { get; set; }
    public int ProyectoID { get; set; }
    public int UsuarioID { get; set; }
    public decimal MontoReembolso { get; set; }
    public DateTime FechaReembolso { get; set; }
}
