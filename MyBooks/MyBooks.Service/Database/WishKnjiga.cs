using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class WishKnjiga
    {
        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public string Naslov { get; set; } = null!;
        public string? Autor { get; set; }
        public string? Napomena { get; set; }
        public string? Prioritet { get; set; }
        public byte[]? Slika { get; set; }
        public DateTime? DatumKreiranja { get; set; }

        public virtual Korisnik Korisnik { get; set; } = null!;
    }
}
