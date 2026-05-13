using System;

namespace backend.Models;

public class Recompensa
{
    public int RecompensaID { get; set; }
    public int ProyectoID { get; set; }
    public int UsuarioID { get; set; }
    public decimal MontoGanancia { get; set; }
    public bool Reclamada { get; set; }
    public DateTime? FechaReclamo { get; set; }
}
