using System;

namespace backend.Models;

public class Evidencia
{
    public int EvidenciaID { get; set; }
    public int ProyectoID { get; set; }
    public string? Titulo { get; set; }
    public string ArchivoURL { get; set; } = string.Empty;
    public string? TipoArchivo { get; set; }
    public DateTime FechaSubida { get; set; }
}
