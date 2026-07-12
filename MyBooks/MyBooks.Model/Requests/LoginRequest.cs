using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model.Requests
{
    public class LoginRequest
    {
        public string Email { get; set; } = null!;

        public string Lozinka { get; set; } = null!;
    }
}
