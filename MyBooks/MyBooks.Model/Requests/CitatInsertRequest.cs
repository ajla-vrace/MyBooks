using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class CitatInsertRequest
    {
        public int IdKnjiga { get; set; }
        public string? TekstCitata { get; set; }
        public int? BrojStranice { get; set; }
        public bool? JeOmiljeni { get; set; }
    }
}
