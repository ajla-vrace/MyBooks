using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class Znacka
    {
        public Znacka()
        {
            KorisnikZnackas = new HashSet<KorisnikZnacka>();
        }

        public int Id { get; set; }
        public string Naziv { get; set; } = null!;
        public string? Opis { get; set; }
        public string? Ikonica { get; set; }

        public virtual ICollection<KorisnikZnacka> KorisnikZnackas { get; set; }
    }
}
