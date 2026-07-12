using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class Knjiga
    {
        public Knjiga()
        {
            Citats = new HashSet<Citat>();
            KnjigaZanrs = new HashSet<KnjigaZanr>();
        }

        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public string Naslov { get; set; } = null!;
        public string Autor { get; set; } = null!;
        public string? Opis { get; set; }
        public string? Biljeske { get; set; }
        public int? Ocjena { get; set; }
        public string? Status { get; set; }
        public string? Recenzija { get; set; }
        public string? Mood { get; set; }
        public bool? IsFavorite { get; set; }
        public byte[]? Slika { get; set; }
        public DateTime? DatumPocetka { get; set; }
        public DateTime? DatumZavrsetka { get; set; }
        public DateTime? DatumKreiranja { get; set; }

        public virtual Korisnik Korisnik { get; set; } = null!;
        public virtual ICollection<Citat> Citats { get; set; }
        public virtual ICollection<KnjigaZanr> KnjigaZanrs { get; set; }
    }
}
