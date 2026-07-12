using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class WishKnjigaInsertRequest
    {
        public string Naslov { get; set; } = null!;

        public string? Autor { get; set; }
        public string? Napomena { get; set; }

        public string? Prioritet { get; set; }
        public string? SlikaBase64 { get; set; }
        public int KorisnikId { get; set; }
    }
}
