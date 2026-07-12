using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class KorisnikZnacka
    {
        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public int ZnackaId { get; set; }
        public DateTime? DatumOtkljucavanja { get; set; }

        public virtual Korisnik Korisnik { get; set; } = null!;
        public virtual Znacka Znacka { get; set; } = null!;
    }
}
