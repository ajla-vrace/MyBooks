using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.SearchObject
{
    public class KorisnikSearchObject : BaseSearchObject
    {
        public int? Id { get; set; }
        public string? Email { get; set; }
        public string? Ime { get; set; }
        // public string? Autor { get; set; }
        // public int? ZanrId { get; set; }
        //public string? Status { get; set; }
    }
}
