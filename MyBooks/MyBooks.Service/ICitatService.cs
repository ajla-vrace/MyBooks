using MyBooks.Model.Requests;
using MyBooks.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface ICitatService : ICRUDService<Model.Citat, Model.SearchObject.CitatSearchObject, Model.Requests.CitatInsertRequest, Model.Requests.CitatUpdateRequest>
    {

    }
}
