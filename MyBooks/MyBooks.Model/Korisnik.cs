using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class Korisnik
    {
        public int Id { get; set; }
        public string Ime { get; set; } = null!;
        public string Email { get; set; } = null!;
        public byte[] LozinkaHash { get; set; } = null!;
        public byte[] LozinkaSalt { get; set; } = null!;
        public DateTime? DatumRegistracije { get; set; }
        public byte[]? ProfilnaSlika { get; set; }
        public int? GodisnjiCilj { get; set; }
        public int? OmiljeniZanrId { get; set; }
    }
}
