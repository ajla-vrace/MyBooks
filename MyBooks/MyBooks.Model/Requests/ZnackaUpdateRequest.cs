using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class ZnackaUpdateRequest
    {
       // public int Id { get; set; }
        public string Naziv { get; set; } = null!;
        public string? Opis { get; set; }
       // public string? Ikonica { get; set; }
    }
}
