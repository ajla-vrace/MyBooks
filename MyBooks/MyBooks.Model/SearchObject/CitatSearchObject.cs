using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.SearchObject
{
    public class CitatSearchObject:BaseSearchObject
    {
        public int IdKnjiga { get; set; }
        //public string? TekstCitata { get; set; }
        //public int? BrojStranice { get; set; }
        public bool? JeOmiljeni { get; set; }
    }
}
