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
    public class CitatService : BaseCRUDService<Model.Citat, Database.Citat, CitatSearchObject, CitatInsertRequest, CitatUpdateRequest>, ICitatService
    {
        public CitatService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Citat> AddFilter(IQueryable<Database.Citat> query, CitatSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);


            // Ako je korisničko ime i naziv usluge uneseno
            filteredQuery = filteredQuery.Include(x => x.IdKnjigaNavigation);

            if (search?.IdKnjiga > 0)
            {
                filteredQuery = filteredQuery.Where(x => x.IdKnjiga == search.IdKnjiga);
            }

            return filteredQuery;
        }


        public override async Task<Model.Citat> Insert(CitatInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.Citat>(insert);

            // Postavi trenutni datum


            // Dodaj u bazu podataka
            _context.Citats.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.Citat>(entity);
        }


        public override async Task<Model.Citat> Update(int id, CitatUpdateRequest update)
        {
            var entity = await _context.Citats.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Citat nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.Citats.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Citat>(entity);
        }
        public CitatiStatistika GetStatistika()
        {
            var danas = DateTime.Today;

            var citati = _context.Citats
                .Include(c => c.IdKnjigaNavigation)
                .OrderByDescending(c => c.DatumKreiranja)
                .ToList();

            bool dodanoDanas = citati.Any(c =>
                c.DatumKreiranja.HasValue &&
                c.DatumKreiranja.Value.Date == danas);

            var danasnjiCitat = citati
                .FirstOrDefault(c =>
                    c.DatumKreiranja.HasValue &&
                    c.DatumKreiranja.Value.Date == danas);

            int trenutniNiz = 0;

            foreach (var c in citati)
            {
                if (!c.DatumKreiranja.HasValue)
                    continue;

                var date = c.DatumKreiranja.Value.Date;

                if (date == danas.AddDays(-trenutniNiz))
                {
                    trenutniNiz++;
                }
                else if (date < danas.AddDays(-trenutniNiz))
                {
                    break;
                }
            }

            int najduziNiz = trenutniNiz;

            return new CitatiStatistika
            {
                DodanoDanas = dodanoDanas,
                TrenutniNiz = trenutniNiz,
                NajduziNiz = najduziNiz,
                TekstCitata = danasnjiCitat?.TekstCitata,
                NazivKnjige = danasnjiCitat?.IdKnjigaNavigation?.Naslov,
                BrojStranice = danasnjiCitat?.BrojStranice
            };
        }
    }
}
