using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using MyBooks.Model;

namespace MyBooks.Service
{
    public class KorisnikZnackaService : BaseCRUDService<Model.KorisnikZnacka, Database.KorisnikZnacka, KorisnikZnackaSearchObject, KorisnikZnackaInsertRequest, KorisnikZnackaUpdateRequest>, IKorisnikZnackaService
    {
        public KorisnikZnackaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }


        public override IQueryable<Database.KorisnikZnacka> AddFilter(
            IQueryable<Database.KorisnikZnacka> query,
            KorisnikZnackaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);


            if (search?.IdKorisnik.HasValue == true)
            {
                filteredQuery =
                    filteredQuery.Where(x =>
                    x.KorisnikId == search.IdKorisnik);
            }


            filteredQuery = filteredQuery
                .Include(x => x.Znacka);


            return filteredQuery;
        }



        public override async Task<Model.KorisnikZnacka> Insert(KorisnikZnackaInsertRequest insert)
        {
            var postoji = await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == insert.IdKorisnik &&
                    x.ZnackaId == insert.IdZnacka);


            if (postoji)
            {
                var postojeca = await _context.KorisnikZnackas
                    .FirstAsync(x =>
                        x.KorisnikId == insert.IdKorisnik &&
                        x.ZnackaId == insert.IdZnacka);

                return _mapper.Map<Model.KorisnikZnacka>(postojeca);
            }


            var entity = _mapper.Map<Database.KorisnikZnacka>(insert);

            entity.DatumOtkljucavanja = DateTime.Now;


            _context.KorisnikZnackas.Add(entity);

            await _context.SaveChangesAsync();


            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }



        public override async Task<Model.KorisnikZnacka> Update(int id, KorisnikZnackaUpdateRequest update)
        {
            var entity = await _context.KorisnikZnackas.FindAsync(id);

            if (entity == null)
            {
                throw new KeyNotFoundException("KorisnikZnacka nije pronađena.");
            }


            _mapper.Map(update, entity);


            _context.KorisnikZnackas.Update(entity);

            await _context.SaveChangesAsync();


            return _mapper.Map<Model.KorisnikZnacka>(entity);
        }




        public async Task ProvjeriZnacke(int korisnikId)
        {

            // BROJ KNJIGA
            var brojKnjiga =
                await _context.Knjigas
                .CountAsync(x =>
                    x.KorisnikId == korisnikId);



            // BROJ CITATA
            var brojCitata =
                await _context.Citats
                .CountAsync(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId);



            // BROJ RAZLIČITIH ŽANROVA
            var brojZanrova =
                await _context.KnjigaZanrs
                .Where(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId)
                .Select(x => x.IdZanr)
                .Distinct()
                .CountAsync();



            // BOOKS

            if (brojKnjiga >= 1)
            {
                await DodajZnackuAkoNema(korisnikId, 1);
            }


            if (brojKnjiga >= 5)
            {
                await DodajZnackuAkoNema(korisnikId, 2);
            }


            if (brojKnjiga >= 10)
            {
                await DodajZnackuAkoNema(korisnikId, 3);
            }



            // QUOTES

            if (brojCitata >= 1)
            {
                await DodajZnackuAkoNema(korisnikId, 4);
            }


            if (brojCitata >= 5)
            {
                await DodajZnackuAkoNema(korisnikId, 5);
            }


            if (brojCitata >= 10)
            {
                await DodajZnackuAkoNema(korisnikId, 6);
            }



            // GENRES

            if (brojZanrova >= 5)
            {
                await DodajZnackuAkoNema(korisnikId, 7);
            }

        }




        private async Task DodajZnackuAkoNema(
            int korisnikId,
            int znackaId)
        {

            var postoji =
                await _context.KorisnikZnackas
                .AnyAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.ZnackaId == znackaId);



            if (!postoji)
            {

                _context.KorisnikZnackas.Add(
                    new Database.KorisnikZnacka
                    {
                        KorisnikId = korisnikId,
                        ZnackaId = znackaId,
                        DatumOtkljucavanja = DateTime.Now
                    });


                await _context.SaveChangesAsync();
            }
        }
    }
}