using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class Zanr
    {
        public Zanr()
        {
            KnjigaZanrs = new HashSet<KnjigaZanr>();
            Korisniks = new HashSet<Korisnik>();
        }

        public int Id { get; set; }
        public string Naziv { get; set; } = null!;

        public virtual ICollection<KnjigaZanr> KnjigaZanrs { get; set; }
        public virtual ICollection<Korisnik> Korisniks { get; set; }
    }
}
