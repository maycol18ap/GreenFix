using System;

namespace backend.Models;

public class Usuario
{
    public int UsuarioID { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string WalletAddress { get; set; } = string.Empty;
    public string TipoUsuario { get; set; } = "Inversor";
    public DateTime FechaRegistro { get; set; }
}
