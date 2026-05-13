using System;

namespace backend.Models;

public class Pago
{
    public int PagoID { get; set; }
    public int ProyectoID { get; set; }
    public int NumeroCuota { get; set; }
    public decimal MontoPago { get; set; }
    public DateTime FechaLimite { get; set; }
    public bool Pagado { get; set; }
    public DateTime? FechaPago { get; set; }
}
