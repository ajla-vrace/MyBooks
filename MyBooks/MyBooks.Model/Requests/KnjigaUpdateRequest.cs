using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class KnjigaUpdateRequest
    {
        public bool IsFavorite { get; set; }
        public string Naslov { get; set; } = null!;

        public string Autor { get; set; } = null!;
        public string? Opis { get; set; }
        public int? Ocjena { get; set; }
        //public int KorisnikId { get; set; }
        //public string? Status { get; set; }
        public string? Recenzija { get; set; }
       // public bool IsFavorite { get; set; }
       // public string? Mood { get; set; }
        public string? SlikaBase64 { get; set; }
        public List<int> ZanroviIds { get; set; } = new List<int>();
    }
}
