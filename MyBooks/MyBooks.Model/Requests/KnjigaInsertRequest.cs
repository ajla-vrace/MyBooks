using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class KnjigaInsertRequest
    {
        //[Required(AllowEmptyStrings = false, ErrorMessage = "Naslov je obavezan.")]
        public string Naslov { get; set; } = null!;

        //[Required(AllowEmptyStrings = false, ErrorMessage = "Sadrzaj je obavezan.")]
        //[MinLength(10, ErrorMessage = "Sadržaj mora imati minimalno 10 znakova.")]

        public string Autor { get; set; } = null!;
        public string? Opis { get; set; }
        public int? Ocjena { get; set; }
       
        public string? Status { get; set; }
        public string? Recenzija { get; set; }
        public bool IsFavorite { get; set; }
        public string? SlikaBase64 { get; set; }
        public List<int> ZanroviIds { get; set; } = new List<int>();
        // public string? SlikaBase64 { get; set; }
        //public string? Status { get; set; }

        //public int? AutorID { get; set; }
        // public DateTime Datum { get; set; }
    }
}
