using System;

namespace backend.Models;

public class Voto
{
    public int VotoID { get; set; }
    public int MilestoneID { get; set; }
    public int UsuarioID { get; set; }
    public bool VotoValor { get; set; }
    public decimal PesoVoto { get; set; }
    public DateTime FechaVoto { get; set; }
}
