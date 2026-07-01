using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class WishKnjiga
    {
        public int Id { get; set; }
        public string Naslov { get; set; } = null!;
       
        public string? Autor { get; set; }
        public string? Napomena { get; set; }
       
        public string? Prioritet { get; set; }
        public byte[]? Slika { get; set; }

    }
}
