using MyBooks.Model.Requests;
using MyBooks.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Service
{
    public interface IZanrService : ICRUDService<Model.Zanr, Model.SearchObject.ZanrSearchObject, Model.Requests.ZanrInsertRequest, Model.Requests.ZanrUpdateRequest>
    {

    }
}
