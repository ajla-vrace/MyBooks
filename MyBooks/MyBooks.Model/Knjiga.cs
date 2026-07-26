using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public partial class Knjiga
    {

        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public string Naslov { get; set; } = null!;
      
        public string Autor { get; set; } = null!;
        public string? Opis { get; set; }
        public int? Ocjena { get; set; }
       
        public string? Status { get; set; }
        public string? Recenzija { get; set; }
        public byte[]? Slika { get; set; }
        public bool IsFavorite { get; set; } = false;
        public string? Mood { get; set; }
        public DateTime? DatumKreiranja { get; set; }
        public List<Zanr> Zanrovi { get; set; } = new List<Zanr>();
      //  public List<Citat> Citati { get; set; } = new List<Citat>();
        // public List<Zanr> KnjigaZanrs { get; set; } = new List<Zanr>();

    }
}
