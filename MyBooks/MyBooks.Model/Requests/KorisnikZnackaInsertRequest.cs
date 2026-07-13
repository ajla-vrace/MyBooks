using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class KorisnikZnackaInsertRequest
    {
        public int IdKorisnik { get; set; }
        public int IdZnacka { get; set; }
    }
}

