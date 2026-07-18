using MyBooks.Model.SearchObject;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.SearchObject
{
    public class KnjigaSearchObject : BaseSearchObject
    {
        public string? Naslov { get; set; }
        public string? Autor { get; set; }
        public int? ZanrId { get; set; }
        public int? KorisnikId { get; set; }
        public bool? NaDanasnjiDan { get; set; }
        //public string? Status { get; set; }
    }
}
