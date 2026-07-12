using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class Korisnik
    {
        public Korisnik()
        {
            Knjigas = new HashSet<Knjiga>();
            KorisnikZnackas = new HashSet<KorisnikZnacka>();
            WishKnjigas = new HashSet<WishKnjiga>();
        }

        public int Id { get; set; }
        public string Ime { get; set; } = null!;
        public string Email { get; set; } = null!;
        public byte[] LozinkaHash { get; set; } = null!;
        public byte[] LozinkaSalt { get; set; } = null!;
        public DateTime? DatumRegistracije { get; set; }
        public byte[]? ProfilnaSlika { get; set; }
        public int? GodisnjiCilj { get; set; }
        public int? OmiljeniZanrId { get; set; }

        public virtual Zanr? OmiljeniZanr { get; set; }
        public virtual ICollection<Knjiga> Knjigas { get; set; }
        public virtual ICollection<KorisnikZnacka> KorisnikZnackas { get; set; }
        public virtual ICollection<WishKnjiga> WishKnjigas { get; set; }
    }
}
