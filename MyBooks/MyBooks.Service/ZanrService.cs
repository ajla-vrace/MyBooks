using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyBooks.Model;
using MyBooks.Service;

namespace MyBooks.Service
{
    public class ZanrService : BaseCRUDService<Model.Zanr, Database.Zanr, ZanrSearchObject, ZanrInsertRequest, ZanrUpdateRequest>, IZanrService
    {
        public ZanrService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Zanr> AddFilter(IQueryable<Database.Zanr> query, ZanrSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            // Ako je korisničko ime i naziv usluge uneseno

            return filteredQuery;
        }


        public override async Task<Model.Zanr> Insert(ZanrInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.Zanr>(insert);

            // Postavi trenutni datum
           

            // Dodaj u bazu podataka
            _context.Zanrs.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.Zanr>(entity);
        }


        public override async Task<Model.Zanr> Update(int id, ZanrUpdateRequest update)
        {
            var entity = await _context.Zanrs.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Knjiga nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.Zanrs.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Zanr>(entity);
        }
    }
}
