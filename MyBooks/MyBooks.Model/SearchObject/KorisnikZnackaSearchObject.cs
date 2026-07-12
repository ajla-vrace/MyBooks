using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.SearchObject
{
    public class KorisnikZnackaSearchObject : BaseSearchObject
    {
        public int? IdKorisnik { get; set; }
        public int? IdZnacka { get; set; }
        //public int? ZanrId { get; set; }
        //public string? Status { get; set; }
    }
}
