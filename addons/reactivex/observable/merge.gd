static func merge_(sources) -> Observable:
	return GDRx.obs.from_iterable(GDRx.to_iterable(sources)).pipe1(GDRx.op.merge_all())
